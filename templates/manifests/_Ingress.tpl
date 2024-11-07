{{- define "chary.Ingress" -}}
{{- $fullName := include "chary.fullname" . -}}
{{- $svcPort := 80 -}}
{{- $className := dig "metadata" "annotations" "kubernetes.io/ingress.class" "" . -}}
{{- if .apiVersion -}}
apiVersion: {{ .apiVersion }}
{{- else if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
spec:
  {{- if and $className (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion) }}
  ingressClassName: {{ $className }}
  {{- end }}
  rules:
  {{- range (dig "spec" "rules" (list (dict "host" "")) . ) }}
  - {{- toYaml . | nindent 4 }}
    host: {{ default (printf "%s.local" $fullName) .host | quote }}
    http:
      paths:
      {{- range (dig "http" "paths" (list (dict "path" "")) . ) }}
      - {{- toYaml . | nindent 8 }}
        path: {{ default "/" .path }}
        {{- $pathType := default "ImplementationSpecific" .pathType -}}
        {{- if and $pathType (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion) }}
        pathType: {{ $pathType }}
        {{- end }}
        backend:
          {{- if semverCompare ">=1.19-0" $.Capabilities.KubeVersion.GitVersion }}
          service:
            name: {{ dig "backend" "service" "name" $fullName . }}
            port:
              number: {{ dig "backend" "service" "port" "number" $svcPort . }}
          {{- else }}
          serviceName: {{ dig "backend" "serviceName" $fullName . }}
          servicePort: {{ dig "backend" "servicePort" $svcPort . }}
          {{- end }}
      {{- end }}
  {{- end }}
{{- end }}