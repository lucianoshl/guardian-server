FROM lucianoshl/guardian-base

RUN apk update && apk upgrade && apk add --update git
RUN rm -rf /var/cache/apk/*