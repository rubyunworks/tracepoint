---
source:
- meta
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks, Thomas Sawyer
  year: '2005'
  license: BSD-2-Clause
replacements: []
alternatives: []
requirements:
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
dependencies: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/tracepoint.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/tracepoint
  code: http://github.com/rubyworks/tracepoint
  mail: http://groups.google.com/groups/rubyworks-mailinglist
extra: {}
load_path:
- lib
revision: 0
created: '2008-08-08'
summary: The perfect alternative to set_trace_func
title: TracePoint
version: 1.2.1
name: tracepoint
description: ! "A TracePoint is a Binding with the addition of event information.\nAmong
  other things, it functions very well as the join-point for\nAOP. In practice it
  provides a better alternative to using \nset_trace_func."
organization: RubyWorks
date: '2011-11-05'
