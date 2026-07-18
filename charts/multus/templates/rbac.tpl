{{- if .Values.rbac.create -}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ include "multus.fullname" . }}
  labels:
    {{- include "multus.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
rules:
  - apiGroups: ["k8s.cni.cncf.io"]
    resources: ["*"]
    verbs: ["*"]
  - apiGroups: [""]
    resources: ["pods", "pods/status"]
    verbs: ["get", "update"]
  - apiGroups: ["", "events.k8s.io"]
    resources: ["events"]
    verbs: ["create", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "multus.fullname" . }}
  labels:
    {{- include "multus.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ include "multus.fullname" . }}
subjects:
  - kind: ServiceAccount
    name: {{ include "multus.serviceAccountName" . }}
    namespace: {{ .Release.Namespace }}
{{- end }}
