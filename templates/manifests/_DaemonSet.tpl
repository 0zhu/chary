{{- define "chary.DaemonSet" -}}
{{ include "chary.Deployment" . }}
{{- end }}