{{- define "gvList" -}}
{{- $groupVersions := . -}}

// Generated documentation. Please do not edit.
:anchor_prefix: k8s-api

[id="reference"]
== {{env "KONFLUX_TITLE"}} API Reference

.Packages
{{- range $groupVersions }}
- {{ asciidocRenderGVLink . }}
{{- end }}

{{ range $groupVersions }}
{{ template "gvDetails" . }}
{{ end }}

{{- end -}}
