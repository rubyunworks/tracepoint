fn = lambda do |e, f, l, m, b, k|
  p Kernel.eval('self', b)
end

set_trace_func(fn)

"  a  ".strip

