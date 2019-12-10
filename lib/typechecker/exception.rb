module TypeChecker
  module Err
    class Inconsistent < StandardError; end
    class ConflictDefinition < StandardError; end
    class DuplicateSignature < StandardError; end
    class AmbiguousMethodCall < StandardError; end
  end
end