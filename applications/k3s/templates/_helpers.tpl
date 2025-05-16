{{/*
Expand the name of the chart.
*/}}
{{- define "k3s.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k3s.fullname" -}}
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
{{- define "k3s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k3s.labels" -}}
helm.sh/chart: {{ include "k3s.chart" . }}
{{ include "k3s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k3s.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k3s.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k3s.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k3s.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "k3s.hostname" -}}
{{- default .Release.Name .Values.service.hostname }}
{{- end }}

{{- define "k3s.serviceAnnotations" -}}
{{- with .Values.serviceAnnotations }}
{{- toYaml . }}
{{- end }}
{{- if gt (len .Values.service.domains) 0 }}
{{- $hostnames := list }}
{{- range .Values.service.domains }}
{{- $hostnames = append $hostnames (printf "%s.%s" (include "k3s.hostname" $ ) . ) }}
{{- $hostnames = append $hostnames (printf "*.%s.%s" (include "k3s.hostname" $ ) . ) }}
{{- end }}
external-dns.alpha.kubernetes.io/hostname: {{ join "," $hostnames  | quote }}
{{- end }}
{{- end }}

{{- define "k3s.apiHost" -}}
{{- printf "%s.%s.svc.cluster.local" (include "k3s.fullname" . ) (.Release.Namespace ) }}
{{- end }}

{{- define "k3s.apiHostExternal" -}}
{{- printf "%s.%s" (include "k3s.hostname" . ) (.Values.service.domains | first) }}
{{- end }}

{{- define "k3s.apiHostExternalAll" -}}
{{- $hosts := list }}
{{- range .Values.service.domains }}
{{- $hosts = append $hosts (printf "%s.%s" (include "k3s.hostname" $ ) . ) }}
{{- end }}
{{- mustToJson $hosts }}
{{- end }}

{{- define "k3s.apiUrl" -}}
{{- printf "https://%s:6443" (include "k3s.apiHost" . ) }}
{{- end }}

{{- define "k3s.apiUrlExternal" -}}
{{- printf "https://%s:6443" (include "k3s.apiHostExternal" . ) }}
{{- end }}

{{- define "k3s.argocdProject" -}}
{{- default (include "k3s.fullname" .) .Values.argoCD.project.name -}}
{{- end }}


{{- define "k3s.appHostnames" -}}
{{- $hosts := list }}
{{- range .Values.service.domains }}
{{- $hosts = append $hosts (printf "%s.%s.%s" $.name (include "k3s.hostname" $ ) . ) }}
{{- end }}
{{- mustToJson $hosts }}
{{- end }}

{{- define "k3s.appHostname" -}}
{{ include "k3s.appHostnames" (dict "Values" .Values "Release" .Release "name" .name ) | mustFromJson | first }}
{{- end }}

{{- define "k3s.datastore-endpoint" -}}
{{- printf "postgres://%s:%s@%s:%d/%s" "postgres" .Values.postgresql.auth.postgresPassword .Values.postgresql.fullnameOverride (.Values.postgresql.primary.service.ports.postgresql | int ) .Values.postgresql.auth.database }}
{{- end }}