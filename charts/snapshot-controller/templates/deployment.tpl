---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "snapshot-controller.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "snapshot-controller.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  # The controller exits if the CRDs stay unavailable past --retry-crd-interval-max
  # (30s default); hold rollouts slightly longer, mirroring upstream.
  minReadySeconds: 35
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
  selector:
    matchLabels:
      {{- include "snapshot-controller.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "snapshot-controller.labels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      enableServiceLinks: false
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "snapshot-controller.serviceAccountName" . }}
      {{- with .Values.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: snapshot-controller
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: {{ include "snapshot-controller.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          args:
            - --v={{ .Values.controller.verbosity }}
            - --leader-election={{ .Values.controller.leaderElection.enabled }}
            {{- if .Values.controller.leaderElection.enabled }}
            - --leader-election-namespace=$(NAMESPACE)
            {{- end }}
            - --http-endpoint=:{{ .Values.controller.metrics.port }}
            {{- if .Values.controller.volumeGroupSnapshots }}
            - --feature-gates=CSIVolumeGroupSnapshot=true
            {{- end }}
            {{- range .Values.controller.extraArgs }}
            - {{ . }}
            {{- end }}
          env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            {{- with .Values.env }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          ports:
            - name: metrics
              containerPort: {{ .Values.controller.metrics.port }}
              protocol: TCP
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12 }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12 }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
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
      {{- with .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
