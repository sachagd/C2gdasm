	.file	"code.c"
	.text
	.globl	main
	.type	main, @function
main:
	movl	$0, %eax
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
