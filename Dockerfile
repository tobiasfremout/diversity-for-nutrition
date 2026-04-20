ARG BASE_IMAGE=315134288138.dkr.ecr.us-east-1.amazonaws.com/r-lambda-d4n-base:latest
FROM ${BASE_IMAGE}

COPY runtime.r functions.r nutrition.r config.r /var/task/
COPY src/ /var/task/src/
RUN chmod 755 -R /var/task/

RUN printf '#!/bin/sh\ncd $LAMBDA_TASK_ROOT\nRscript runtime.r' > /var/runtime/bootstrap \
    && chmod +x /var/runtime/bootstrap

CMD ["functions.mainNutrition"]
