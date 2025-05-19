{{- define "my-apps.namespacePrefix" -}}
{{- (printf "%s-" .Values.destination.namespacePrefix) | trimPrefix "-" }}
{{- end }}

{{- define "my-apps.namePrefix" -}}
{{- (printf "%s-" ( .Values.namePrefix | default .Release.Name )) | trimPrefix "-" }}
{{- end }}
$.