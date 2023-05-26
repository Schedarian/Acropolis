Event_MemberUpdate = lambda { |vars|
  vars[:bot].member_update { |event|
    event.member.add_role(vars[:config][:timeout_role_id]) if event.member.timeout?
  }
}
