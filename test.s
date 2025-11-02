	.file	"test.c"
	.text
	.globl	main
	.type	main, @function
main:
	subl	$4032, %esp
	movb	$1, 4015(%esp)
	movl	$0, 4028(%esp)
	movl	$2, 4024(%esp)
	jmp	.L2
.L8:
	movl	$1, 4020(%esp)
	movl	$0, 4016(%esp)
	jmp	.L3
.L6:
	movl	4016(%esp), %eax
	movl	12(%esp,%eax,4), %ecx
	movl	4024(%esp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	testl	%eax, %eax
	jne	.L4
	movl	$0, 4020(%esp)
.L4:
	addl	$1, 4016(%esp)
.L3:
	movl	4016(%esp), %eax
	cmpl	4028(%esp), %eax
	jge	.L5
	movl	4016(%esp), %eax
	movl	12(%esp,%eax,4), %edx
	movl	4016(%esp), %eax
	movl	12(%esp,%eax,4), %eax
	imull	%edx, %eax
	cmpl	%eax, 4024(%esp)
	jl	.L5
	cmpl	$0, 4020(%esp)
	jne	.L6
.L5:
	cmpl	$0, 4020(%esp)
	je	.L7
	movl	4028(%esp), %eax
	leal	1(%eax), %edx
	movl	%edx, 4028(%esp)
	movl	4024(%esp), %edx
	movl	%edx, 12(%esp,%eax,4)
.L7:
	addl	$1, 4024(%esp)
.L2:
	cmpl	$999, 4028(%esp)
	jle	.L8
	movl	$0, %eax
	addl	$4032, %esp
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
