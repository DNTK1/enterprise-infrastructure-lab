apiVersion: apps/v1
kind: Deployment
metadata:
  name: securehash-status
  namespace: status-page
  labels:
    app: securehash-status

spec:
  replicas: 2

  selector:
    matchLabels:
      app: securehash-status

  template:
    metadata:
      labels:
        app: securehash-status

    spec:
      imagePullSecrets:
        - name: gitlab-registry

      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        seccompProfile:
          type: RuntimeDefault

      containers:
        - name: securehash-status
          image: registry.domena.lab/devops-lab/securehash-status/app:${IMAGE_TAG}
          imagePullPolicy: IfNotPresent

          ports:
            - name: http
              containerPort: 8000
              protocol: TCP

          env:
            - name: APP_VERSION
              value: "${IMAGE_TAG}"

            - name: GIT_SHA
              value: "${GIT_COMMIT_FULL}"

            - name: BUILD_NUMBER
              value: "${BUILD_NUMBER}"

          readinessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 3
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 3

          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 3

          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 250m
              memory: 256Mi

          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
