{{- define "my-apps.namespacePrefix" -}}
{{- (printf "%s-" .Values.destination.namespacePrefix) | trimPrefix "-" }}
{{- end }}
