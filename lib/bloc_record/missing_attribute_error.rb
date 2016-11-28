class MissingAttributeError < StandardError
  def initialize(msg="MissingAttributeError: missing attribute: <attribute>")
    super
  end
end
