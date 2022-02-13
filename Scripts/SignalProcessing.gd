
class_name SignalProcessing


static func getFundFreq(spectrum : AudioEffectSpectrumAnalyzerInstance, min_magnitude : float =0.02):
	if is_instance_valid(spectrum):
		var max_hz = 0
		var hz_val = 0
		var prev_hz = 0
		for i in range(50, 2000):
			var hz = i;
			var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			if magnitude > max_hz:
				max_hz = magnitude
				hz_val = i
			prev_hz = hz
		if min_magnitude < max_hz:
			return hz_val




func fft(x: Array) -> Array:

	# how long the unput is
	var n := x.size()
	
	# stop if we are too short
	if n <= 1:
		return x
	
	# two split arrays
	var even := []
	var odd := []
	
	# split the input
	for i in range(n):
		
		if (i & 1) == 0:
			even.append(x[i])
		else:
			odd.append(x[i])
	
	# recursion
	even = fft(even)
	odd = fft(odd)
	
	var t := []
	
	for i in range(n / 2):
	
		# this is complex number math
		# complex part
		var c_part := -TAU * (float(i) / float(n))
		
		var exp_out := Vector2(
			cos(c_part),
			sin(c_part) 
		)
		
		# then, complex multiplication
		var a := exp_out.x
		var b := exp_out.y
		var c := odd[i].x as float
		var d := odd[i].y as float
	
		var mult_out = Vector2(a*c - b*d, a*d + b*c)
		
		# and add it
		t.append(mult_out)
	
	# output array
	var output := []
	
	# and calculate the putputs
	for i in range(n / 2):
		
		output.append(even[i] + t[i])
	
	# other side
	for i in range(n / 2):
	
		output.append(even[i] - t[i])
	
	# return
	return output
