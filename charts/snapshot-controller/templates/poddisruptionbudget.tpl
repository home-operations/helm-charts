{{- with .Values.podDisruptionBudget }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "snapshot-controller.fullname" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "snapshot-controller.labels" $ | nindent 4 }}
spec:
  {{- toYaml . | nindent 2 }}
  selector:
    matchLabels:
      {{- include "snapshot-controller.selectorLabels" $ | nindent 6 }}
{{- end }}
