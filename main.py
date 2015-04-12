
class A(object):
	def __init__(self, a):
		self.a = a 

class B(A):
	def __init__(self, a):
		super(B, self).__init__(a)

	

b = B(2)
