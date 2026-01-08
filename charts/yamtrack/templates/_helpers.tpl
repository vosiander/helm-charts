{{/*
Expand the name of the chart.
*/}}
{{- define "yamtrack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "yamtrack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "yamtrack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "yamtrack.labels" -}}
helm.sh/chart: {{ include "yamtrack.chart" . }}
{{ include "yamtrack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "yamtrack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "yamtrack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "yamtrack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "yamtrack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the secret name
*/}}
{{- define "yamtrack.secretName" -}}
{{- if .Values.yamtrack.existingSecret }}
{{- .Values.yamtrack.existingSecret }}
{{- else }}
{{- include "yamtrack.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL host
Returns the internal subchart service name or external host
*/}}
{{- define "yamtrack.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else }}
{{- .Values.database.host }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL port
*/}}
{{- define "yamtrack.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- "5432" }}
{{- else }}
{{- .Values.database.port | default "5432" }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL database name
*/}}
{{- define "yamtrack.postgresql.database" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | default "yamtrack" }}
{{- else }}
{{- .Values.database.name | default "yamtrack" }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL user
*/}}
{{- define "yamtrack.postgresql.user" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | default "yamtrack" }}
{{- else }}
{{- .Values.database.user | default "yamtrack" }}
{{- end }}
{{- end }}

{{/*
Get Redis URL
Returns the internal subchart service URL or external URL
*/}}
{{- define "yamtrack.redis.url" -}}
{{- if .Values.redis.enabled }}
{{- printf "redis://%s-redis-master:6379" .Release.Name }}
{{- else }}
{{- .Values.externalRedis.url }}
{{- end }}
{{- end }}

{{/*
Check if database is configured (either internal or external)
*/}}
{{- define "yamtrack.database.enabled" -}}
{{- if or .Values.postgresql.enabled .Values.database.host }}
{{- true }}
{{- end }}
{{- end }}

{{/*
Check if redis is configured (either internal or external)
*/}}
{{- define "yamtrack.redis.enabled" -}}
{{- if or .Values.redis.enabled .Values.externalRedis.url }}
{{- true }}
{{- end }}
{{- end }}
