{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* ######### Hostname templates */}}

{{/*
Returns the hostname.
If the hostname is set in `global.hosts.gitlab.name`, that will be returned,
otherwise the hostname will be assembed using `gitlab` as the prefix, and the `assembleHost` function.
*/}}
{{- define "gitlabHost" -}}
{{- coalesce .Values.global.hosts.gitlab.name (include "assembleHost"  (dict "name" "gitlab" "context" . )) -}}
{{- end -}}


{{/* ######### Utility templates */}}

{{/*
  A helper function for assembling a hostname using the base domain specified in `global.hosts.domain`
  Takes a `Map/Dictonary` as an argument. Where key `name` is the domain to build, and `context` should be a
  reference to the chart's $ object.
  eg: `template "assembleHost" (dict "name" "minio" "context" .)`

  The hostname will be the combined name with the domain. eg: If domain is `example.local`, it will produce `minio.example.local`
  Additionally if `global.hosts.hostSuffix` is set, it will append a hyphen, then the suffix to the name:
  eg: If hostSuffix is `beta` it will produce `minio-beta.example.local`
*/}}
{{- define "assembleHost" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $result := dict -}}
{{- if $context.Values.global.hosts.domain -}}
{{-   $_ := set $result "domainHost" (printf ".%s" $context.Values.global.hosts.domain) -}}
{{-   if $context.Values.global.hosts.hostSuffix -}}
{{-     $_ := set $result "domainHost" (printf "-%s%s" $context.Values.global.hosts.hostSuffix $result.domainHost) -}}
{{-   end -}}
{{-   $_ := set $result "domainHost" (printf "%s%s" $name $result.domainHost) -}}
{{- end -}}
{{- $result.domainHost -}}
{{- end -}}

{{/* ######### cert-manager templates */}}

{{- define "gitlab.certmanager_annotations" -}}
{{- if (pluck "configureCertmanager" .Values.global.ingress .Values.ingress (dict "configureCertmanager" false) | first) -}}
certmanager.k8s.io/issuer: "{{ .Release.Name }}-issuer"
{{- end -}}
{{- end -}}

{{/* ######### postgresql templates */}}

{{/*
Return the db hostname
If an external postgresl host is provided, it will use that, otherwise it will fallback
to the service name
This overrides the upstream postegresql chart so that we can deterministically
use the name of the service the upstream chart creates
*/}}
{{- define "gitlab.psql.host" -}}
{{- if .Values.global.psql.host -}}
{{- .Values.global.psql.host | quote -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "postgresql" -}}
{{- end -}}
{{- end -}}

{{/*
Alias of gitlab.psql.host
*/}}
{{- define "postgresql.fullname" -}}
{{- template "gitlab.psql.host" . -}}
{{- end -}}

{{/*
Return the db database name
*/}}
{{- define "gitlab.psql.database" -}}
{{- coalesce .Values.global.psql.database "gitlabhq_production" | quote -}}
{{- end -}}

{{/*
Return the db username
If the postgresql username is provided, it will use that, otherwise it will fallback
to "gitlab" default
*/}}
{{- define "gitlab.psql.username" -}}
{{- coalesce .Values.global.psql.username "gitlab" -}}
{{- end -}}

{{/*
Return the db port
If the postgresql port is provided, it will use that, otherwise it will fallback
to 5432 default
*/}}
{{- define "gitlab.psql.port" -}}
{{- coalesce .Values.global.psql.port 5432 -}}
{{- end -}}

{{/*
Return the secret name
Uses the equivalent of postegresql.fullname to match upstream postgres chart by default
  and falls back to .Values.global.psql.secretName when using an external postegresql
*/}}
{{- define "postgresql.password.secret" -}}
{{- default (printf "%s-%s" .Release.Name "postgresql-password") .Values.global.psql.password.secret | quote -}}
{{- end -}}

{{/*
Return the name of the key in a secret that contains the postgres password
Uses `postgres-password` to match upstream postgresql chart when not using an
  external postegresql
*/}}
{{- define "postgresql.password.key" -}}
{{- default "postgres-password" .Values.global.psql.password.key | quote -}}
{{- end -}}

{{/* ######### ingress templates */}}

{{/*
Returns the nginx ingress class
*/}}
{{- define "gitlab.ingressclass" -}}
{{- pluck "class" .Values.global.ingress (dict "class" (printf "%s-nginx" .Release.Name)) | first -}}
{{- end -}}