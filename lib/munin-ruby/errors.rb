module Munin
  class MuninError      < StandardError ; end
  class ConnectionError < MuninError    ; end
  class AccessDenied    < MuninError    ; end
  class InvalidResponse < MuninError    ; end
  class UnknownService  < MuninError    ; end
  class BadExit         < MuninError    ; end
end