Event_MemberUpdate = lambda { |vars|
  vars[:bot].member_update { |event|
    event.member.timeout? ? vars[:timeoutmanager].add_user(event.member) : vars[:timeoutmanager].remove_user(event.member)
  }
}
