{{- range .Values.volumeGroupSnapshotClasses }}
---
apiVersion: groupsnapshot.storage.k8s.io/v1
kind: VolumeGroupSnapshotClass
metadata:
  name: {{ .name }}
  labels:
    {{- include "snapshot-controller.labels" $ | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
driver: {{ .driver }}
deletionPolicy: {{ .deletionPolicy | default "Delete" }}
{{- with .parameters }}
parameters:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
