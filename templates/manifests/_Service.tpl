{{- define "chary.Service" -}}
apiVersion: {{ default "v1" .apiVersion }}
spec:
  ports:
  {{- range (dig "spec" "ports" (list (dict "port" "")) .) }}
  - {{- toYaml . | nindent 4 }}
    port: {{ default "80" .port }}
  {{- end }}
  selector:
    {{- include "chary.selectorLabels" . | nindent 4 }}
    {{- with dig "spec" "selector" (dict) . }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
{{- end }}