---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "multus.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "multus.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "multus.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "multus.labels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      enableServiceLinks: false
      hostNetwork: true
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "multus.serviceAccountName" . }}
      {{- with .Values.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      {{- if .Values.cniPlugins.enabled }}
      initContainers:
        # The image entrypoint rsyncs the plugin binaries to /host/opt/cni/bin.
        - name: cni-plugins
          image: "{{ .Values.cniPlugins.image.repository }}:{{ .Values.cniPlugins.image.tag }}"
          imagePullPolicy: {{ .Values.cniPlugins.image.pullPolicy }}
          resources:
            {{- toYaml .Values.cniPlugins.resources | nindent 12 }}
          volumeMounts:
            - name: cni-bin
              mountPath: /host/opt/cni/bin
      {{- end }}
      containers:
        - name: multus
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: {{ include "multus.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          args:
            - --cleanup-config-on-exit
            - --multus-cni-conf-dir=/tmp
            {{- range .Values.extraArgs }}
            - {{ . }}
            {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: cni-net
              mountPath: /host/etc/cni/net.d
            - name: cni-bin
              mountPath: /host/opt/cni/bin
            # --multus-cni-conf-dir target; the root filesystem is read-only.
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: cni-net
          hostPath:
            path: {{ .Values.cni.netDir }}
        - name: cni-bin
          hostPath:
            path: {{ .Values.cni.binDir }}
        - name: tmp
          emptyDir: {}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
