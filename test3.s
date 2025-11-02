	.file	"test.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	subl	$4016, %esp
	.cfi_def_cfa_offset 4020
	movl	$0, 4012(%esp)
	movl	$2, 4008(%esp)
	jmp	.L2
.L8:
	movl	$1, 4004(%esp)
	movl	$0, 4000(%esp)
	jmp	.L3
.L6:
	movl	4000(%esp), %eax
	movl	(%esp,%eax,4), %ecx
	movl	4008(%esp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	testl	%eax, %eax
	jne	.L4
	movl	$0, 4004(%esp)
.L4:
	addl	$1, 4000(%esp)
.L3:
	movl	4000(%esp), %eax
	cmpl	4012(%esp), %eax
	jge	.L5
	movl	4000(%esp), %eax
	movl	(%esp,%eax,4), %edx
	movl	4000(%esp), %eax
	movl	(%esp,%eax,4), %eax
	imull	%edx, %eax
	cmpl	%eax, 4008(%esp)
	jl	.L5
	cmpl	$0, 4004(%esp)
	jne	.L6
.L5:
	cmpl	$0, 4004(%esp)
	je	.L7
	movl	4012(%esp), %eax
	leal	1(%eax), %edx
	movl	%edx, 4012(%esp)
	movl	4008(%esp), %edx
	movl	%edx, (%esp,%eax,4)
.L7:
	addl	$1, 4008(%esp)
.L2:
	cmpl	$999, 4012(%esp)
	jle	.L8
	movl	$0, %eax
	addl	$4016, %esp
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
