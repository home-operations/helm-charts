---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "snapshot-controller.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "snapshot-controller.labels" . | nindent 4 }}
  {{- with .Values.controller.metrics.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: ClusterIP
  ports:
    - name: metrics
      port: {{ .Values.controller.metrics.port }}
      targetPort: metrics
      protocol: TCP
  selector:
    {{- include "snapshot-controller.selectorLabels" . | nindent 4 }}
