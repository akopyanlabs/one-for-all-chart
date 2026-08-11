{{/*
Reusable ConfigMap template for single or multi app.

Each item supports:
  - data: map of string -> plain text value (ConfigMap.data)

Parameters:
  root: root . context
  app:  application values (single or item from apps[])
*/}}
{{- define "ofa.configmap" -}}
{{- $root := .root }}
{{- $app := .app }}
{{- if $app.configmap }}
{{- range $app.configmap }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "ofa.fullname" $root }}-{{ .name }}-configmap
  labels:
    app.kubernetes.io/name: {{ .name | default (include "ofa.fullname" $root) }}
    {{- include "ofa.labels" $root | nindent 4 }}
{{- with .data }}
data:
  {{- toYaml . | nindent 2 }}
{{- else }}
data: {}
{{- end }}
---
{{- end }}

{{- end }}
{{- end }}
