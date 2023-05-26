Event_MemberTyping = lambda { |vars|
  vars[:bot].typing { |event|
    event.member.remove_role(vars[:config][:timeout_role_id]) unless event.member.timeout?
  }
}
