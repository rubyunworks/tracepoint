--- 
name: tracepoint
repositories: 
  public: git://github.com/rubyworks/tracepoint.git
title: TracePoint
contact: Thomas Sawyer <transfire@gmail.com>
requires: 
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
resources: 
  code: http://github.com/rubyworks/tracepoint
  home: http://rubyworks.github.com/tracepoint
pom_verison: 1.0.0
manifest: 
- .ruby
- lib/tracepoint.rb
- lib/tracepoint.yml
- qed/trace.rdoc
- HISTORY.rdoc
- LICENSE.txt
- README.rdoc
- VERSION
version: 1.2.0
copyright: (c) 2005 Thomas Sawyer
licenses: 
- Apache 2.0
description: A TracePoint is a Binding with the addition of event information. Among other things, it functions very well as the join-point for AOP. In practice it provides a better alternative to using
organization: RubyWorks
summary: "The perfect alternative to #set_trace_func"
authors: 
- Thomas Sawyer
created: 2008-08-08
