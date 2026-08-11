{{/*
Reusable Service body. Renders a single Service object.
Parameters:
  root:    root . context
  app:     application values (single or item from apps[])
  svc:     the service definition (item from app.services[] or app.service)
  svcName: resource name for this Service
*/}}
{{- define "ofa.service.body" -}}
{{- $root := .root }}
{{- $app := .app }}
{{- $svc := .svc }}
{{- $svcName := .svcName }}
{{- $appversion := "latest" -}}
{{- if $app.image -}}
{{-   $appversion = $app.image.tag | default "latest" -}}
{{- else if $root.Values.global.image -}}
{{-   $appversion = $root.Values.global.image.tag | default "latest" -}}
{{- else -}}
{{-   $appversion = $root.Values.image.tag | default "latest" -}}
{{- end -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ $svcName }}
  labels:
    app.kubernetes.io/name: {{ $app.name | default (include "ofa.fullname" $root) }}
    app.kubernetes.io/version: "{{ $appversion }}"
    {{- include "ofa.labels" $root | nindent 4 }}
spec:
  {{- if $svc.type }}
  type: {{ $svc.type | default "ClusterIP" }}
  {{- end }}
  {{- if $svc.loadBalancerIP }}
  loadBalancerIP: {{ $svc.loadBalancerIP }}
  {{- end }}
  {{- if $svc.externalIPs }}
  externalIPs:
    {{- toYaml $svc.externalIPs | nindent 4 }}
  {{- end }}
  {{- if $svc.externalTrafficPolicy }}
  externalTrafficPolicy: {{ $svc.externalTrafficPolicy }}
  {{- end }}
  {{- if $svc.sessionAffinity }}
  sessionAffinity: {{ $svc.sessionAffinity }}
  {{- end }}
  ports:
    {{- range $svc.ports }}
    - name: {{ .name | default "http" }}
      protocol: {{ .protocol | default "TCP" }}
      port: {{ .port }}
      targetPort: {{ .targetPort | default .port }}
      {{- if .nodePort }}
      nodePort: {{ .nodePort }}
      {{- end }}
    {{- end }}
  selector:
    app.kubernetes.io/name: {{ $app.name | default (include "ofa.fullname" $root) }}
    {{- include "ofa.selectorLabels" $root | nindent 4 }}
{{- end }}

{{/*
Render Services for an app.
Resolution order:
  - if app.services[] is set → render one Service per item (name required)
  - else if app.service is set → render a single Service (backward compatible)
Parameters:
  root: root . context
  app:  application values (single or item from apps[])
*/}}
{{- define "ofa.services" -}}
{{- $root := .root }}
{{- $app := .app }}
{{- if $app.services }}
{{- range $app.services }}
{{- $svcName := .name | default (include "ofa.fullname" $root) }}
{{ include "ofa.service.body" (dict "root" $root "app" $app "svc" . "svcName" $svcName) }}
---
{{- end }}
{{- else if $app.service }}
{{- $svcName := $app.service.name | default $app.name | default (include "ofa.fullname" $root) }}
{{ include "ofa.service.body" (dict "root" $root "app" $app "svc" $app.service "svcName" $svcName) }}
{{- end }}
{{- end }}
