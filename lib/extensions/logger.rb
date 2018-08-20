require 'logger'
# Monkeypatch a 'trace' loglevel into ruby Logger
class Logger
    module Severity; TRACE=-1;end
    def trace(progname = nil, &block);add(TRACE, nil, progname, &block);end
    def trace?; @level <= TRACE; end
end