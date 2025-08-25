; Custom: distinguish method names in member call expressions
; Example: today.setHours() -> setHours gets @method.call

((call_expression
  function: (member_expression
    property: (property_identifier) @method.call)))

; Optional chaining calls: today?.setHours()
((call_expression
  function: (optional_chain
    (member_expression
      property: (property_identifier) @method.call))))

