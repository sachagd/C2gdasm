	.file	"snake.c"
	.text
	.globl	main
	.type	main, @function
main:
	subl	$16, %esp
	movl	$256, 12(%esp)
	movl	$342, 8(%esp)
	movl	12(%esp), %eax
	imull	8(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$0, %eax
	addl	$16, %esp
	ret
	.size	main, .-main
	.globl	lt
	.type	lt, @function
lt:
	subl	$16, %esp
	movl	20(%esp), %eax
	imull	24(%esp), %eax
	movl	%eax, 12(%esp)
	cmpl	$0, 12(%esp)
	jns	.L4
	movl	$0, %eax
	jmp	.L3
.L4:
.L3:
	addl	$16, %esp
	ret
	.size	lt, .-lt
	.section	.note.GNU-stack,"",@progbits
