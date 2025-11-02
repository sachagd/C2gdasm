	.file	"test2.c"
	.text
	.globl	main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	subl	$20, %esp
	subl	$12, %esp
	pushl	$32
	call	malloc
	addl	$16, %esp
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$4, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$8, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$12, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$16, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$20, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$24, %eax
	movl	$199, (%eax)
	movl	-12(%ebp), %eax
	addl	$28, %eax
	movl	$199, (%eax)
	subl	$12, %esp
	pushl	-12(%ebp)
	call	free
	addl	$16, %esp
	movl	$0, %eax
	movl	-4(%ebp), %ecx
	leave
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
