# frozen_string_literal: true

Cachy.cache_store = Moneta.new(:File, dir: '/tmp/guardian')
