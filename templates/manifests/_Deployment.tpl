{{- define "chary.Deployment" -}}
{{- $image := default (dict) .Values.image -}}
apiVersion: {{ default "apps/v1" .apiVersion }}
spec:
  selector:
    matchLabels:
      {{- include "chary.selectorLabels" . | nindent 6 }}
      {{- with dig "spec" "selector" "matchLabels" (dict) . }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
  template:
    metadata:
      labels:
        {{- include "chary.labels" . | nindent 8 }}
        {{- with dig "spec" "template" "metadata" "labels" (dict) . }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      containers:
      {{- range (dig "spec" "template" "spec" "containers" (list (dict "name" "")) .) }}
      - {{- toYaml . | nindent 8 }}
        image: {{ default (
          printf "%s:%s"
            (dig "repository" "nginx" $image)
            (dig "tag" (default "alpine" $.Chart.AppVersion) $image)
          ) .image }}
        name: {{ default (include "chary.name" $) .name }}
      {{- end }}
{{- end }}