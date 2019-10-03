FROM lambci/lambda:build-python3.6

WORKDIR /var/task
ENV WORKDIR /var/task

# Necessary packages here
RUN mkdir -p packages/ && \
    pip install boto3 -t packages/

COPY handler.py "$WORKDIR/handler.py"

RUN zip -r9 $WORKDIR/package.zip packages/ handler.py
