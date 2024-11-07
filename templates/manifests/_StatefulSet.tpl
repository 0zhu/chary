{{- define "chary.StatefulSet" -}}
{{ include "chary.Deployment" . }}
{{- end }}