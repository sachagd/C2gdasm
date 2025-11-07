	.file	"snake.c"
	.text
	.globl	gd_putpixel
	.type	gd_putpixel, @function
gd_putpixel:
	subl	$12, %esp
	movl	20(%esp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movl	%eax, %edx
	movl	16(%esp), %eax
	leal	(%edx,%eax), %ecx
	movl	24(%esp), %eax
	movl	%eax, %edx
	movl	%ecx, %eax
	call	gd_putpixel_simplified
	nop
	addl	$12, %esp
	ret
	.size	gd_putpixel, .-gd_putpixel
	.globl	gd_rect
	.type	gd_rect, @function
gd_rect:
	subl	$28, %esp
	movl	$0, 12(%esp)
	jmp	.L3
.L6:
	movl	$0, 8(%esp)
	jmp	.L4
.L5:
	movl	36(%esp), %edx
	movl	8(%esp), %eax
	addl	%eax, %edx
	movl	32(%esp), %ecx
	movl	12(%esp), %eax
	addl	%ecx, %eax
	subl	$4, %esp
	pushl	52(%esp)
	pushl	%edx
	pushl	%eax
	call	gd_putpixel
	addl	$16, %esp
	addl	$1, 8(%esp)
.L4:
	movl	8(%esp), %eax
	cmpl	40(%esp), %eax
	jl	.L5
	addl	$1, 12(%esp)
.L3:
	movl	12(%esp), %eax
	cmpl	44(%esp), %eax
	jl	.L6
	nop
	nop
	addl	$28, %esp
	ret
	.size	gd_rect, .-gd_rect
	.type	on_snake_circ, @function
on_snake_circ:
	subl	$16, %esp
	movl	$0, 12(%esp)
	jmp	.L8
.L11:
	movl	24(%esp), %eax
	subl	12(%esp), %eax
	addl	$512, %eax
	cltd
	shrl	$23, %edx
	addl	%edx, %eax
	andl	$511, %eax
	subl	%edx, %eax
	movl	%eax, 8(%esp)
	movl	8(%esp), %eax
	leal	0(,%eax,8), %edx
	movl	20(%esp), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	cmpl	%eax, 32(%esp)
	jne	.L9
	movl	8(%esp), %eax
	leal	0(,%eax,8), %edx
	movl	20(%esp), %eax
	addl	%edx, %eax
	movl	4(%eax), %eax
	cmpl	%eax, 36(%esp)
	jne	.L9
	movl	$1, %eax
	jmp	.L10
.L9:
	addl	$1, 12(%esp)
.L8:
	movl	12(%esp), %eax
	cmpl	28(%esp), %eax
	jl	.L11
	movl	$0, %eax
.L10:
	addl	$16, %esp
	ret
	.size	on_snake_circ, .-on_snake_circ
	.type	spawn_apple, @function
spawn_apple:
	subl	$12, %esp
.L13:
	movl	$80, %eax
	call	gd_randint
	movl	28(%esp), %edx
	movl	%eax, (%edx)
	movl	$50, %eax
	call	gd_randint
	movl	32(%esp), %edx
	movl	%eax, (%edx)
	movl	32(%esp), %eax
	movl	(%eax), %edx
	movl	28(%esp), %eax
	movl	(%eax), %eax
	subl	$12, %esp
	pushl	%edx
	pushl	%eax
	pushl	44(%esp)
	pushl	44(%esp)
	pushl	44(%esp)
	call	on_snake_circ
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L13
	nop
	nop
	addl	$12, %esp
	ret
	.size	spawn_apple, .-spawn_apple
	.globl	main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	subl	$4096, %esp
	orl	$0, (%esp)
	subl	$52, %esp
	movl	$2, -12(%ebp)
	movl	$3, -16(%ebp)
	movl	$1, -20(%ebp)
	movl	$0, -24(%ebp)
	movl	$40, -4140(%ebp)
	movl	$25, -4136(%ebp)
	movl	$39, -4132(%ebp)
	movl	$25, -4128(%ebp)
	movl	$38, -4124(%ebp)
	movl	$25, -4120(%ebp)
	subl	$12, %esp
	leal	-4148(%ebp), %eax
	pushl	%eax
	leal	-4144(%ebp), %eax
	pushl	%eax
	pushl	-16(%ebp)
	pushl	-12(%ebp)
	leal	-4140(%ebp), %eax
	pushl	%eax
	call	spawn_apple
	addl	$32, %esp
	movl	$0, -28(%ebp)
	jmp	.L15
.L16:
	movl	-28(%ebp), %eax
	movl	-4136(%ebp,%eax,8), %edx
	movl	-28(%ebp), %eax
	movl	-4140(%ebp,%eax,8), %eax
	subl	$4, %esp
	pushl	$0
	pushl	%edx
	pushl	%eax
	call	gd_putpixel
	addl	$16, %esp
	addl	$1, -28(%ebp)
.L15:
	movl	-28(%ebp), %eax
	cmpl	-16(%ebp), %eax
	jl	.L16
	movl	-4148(%ebp), %edx
	movl	-4144(%ebp), %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_putpixel
	addl	$16, %esp
.L29:
	call	gd_up_pressed
	testl	%eax, %eax
	je	.L17
	cmpl	$0, -24(%ebp)
	jne	.L17
	movl	$0, -20(%ebp)
	movl	$-1, -24(%ebp)
	jmp	.L18
.L17:
	call	gd_w_pressed
	testl	%eax, %eax
	je	.L19
	cmpl	$0, -24(%ebp)
	jne	.L19
	movl	$0, -20(%ebp)
	movl	$1, -24(%ebp)
	jmp	.L18
.L19:
	call	gd_left_pressed
	testl	%eax, %eax
	je	.L20
	cmpl	$0, -20(%ebp)
	jne	.L20
	movl	$-1, -20(%ebp)
	movl	$0, -24(%ebp)
	jmp	.L18
.L20:
	call	gd_right_pressed
	testl	%eax, %eax
	je	.L18
	cmpl	$0, -20(%ebp)
	jne	.L18
	movl	$1, -20(%ebp)
	movl	$0, -24(%ebp)
.L18:
	movl	-12(%ebp), %eax
	movl	-4140(%ebp,%eax,8), %edx
	movl	-20(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -32(%ebp)
	movl	-12(%ebp), %eax
	movl	-4136(%ebp,%eax,8), %edx
	movl	-24(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -36(%ebp)
	cmpl	$0, -32(%ebp)
	js	.L21
	cmpl	$79, -32(%ebp)
	jg	.L21
	cmpl	$0, -36(%ebp)
	js	.L21
	cmpl	$49, -36(%ebp)
	jg	.L21
	subl	$12, %esp
	pushl	-36(%ebp)
	pushl	-32(%ebp)
	pushl	-16(%ebp)
	pushl	-12(%ebp)
	leal	-4140(%ebp), %eax
	pushl	%eax
	call	on_snake_circ
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L31
	movl	-4144(%ebp), %eax
	cmpl	%eax, -32(%ebp)
	jne	.L23
	movl	-4148(%ebp), %eax
	cmpl	%eax, -36(%ebp)
	jne	.L23
	movl	$1, %eax
	jmp	.L24
.L23:
	movl	$0, %eax
.L24:
	movl	%eax, -40(%ebp)
	cmpl	$0, -40(%ebp)
	jne	.L25
	movl	-16(%ebp), %eax
	leal	-1(%eax), %edx
	movl	-12(%ebp), %eax
	subl	%edx, %eax
	addl	$512, %eax
	cltd
	shrl	$23, %edx
	addl	%edx, %eax
	andl	$511, %eax
	subl	%edx, %eax
	movl	%eax, -44(%ebp)
	movl	-44(%ebp), %eax
	movl	-4136(%ebp,%eax,8), %edx
	movl	-44(%ebp), %eax
	movl	-4140(%ebp,%eax,8), %eax
	subl	$4, %esp
	pushl	$1
	pushl	%edx
	pushl	%eax
	call	gd_putpixel
	addl	$16, %esp
	jmp	.L26
.L25:
	cmpl	$511, -16(%ebp)
	jg	.L32
	addl	$1, -16(%ebp)
.L26:
	movl	-12(%ebp), %eax
	addl	$1, %eax
	cltd
	shrl	$23, %edx
	addl	%edx, %eax
	andl	$511, %eax
	subl	%edx, %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	-32(%ebp), %edx
	movl	%edx, -4140(%ebp,%eax,8)
	movl	-12(%ebp), %eax
	movl	-36(%ebp), %edx
	movl	%edx, -4136(%ebp,%eax,8)
	subl	$4, %esp
	pushl	$0
	pushl	-36(%ebp)
	pushl	-32(%ebp)
	call	gd_putpixel
	addl	$16, %esp
	cmpl	$0, -40(%ebp)
	je	.L28
	subl	$12, %esp
	leal	-4148(%ebp), %eax
	pushl	%eax
	leal	-4144(%ebp), %eax
	pushl	%eax
	pushl	-16(%ebp)
	pushl	-12(%ebp)
	leal	-4140(%ebp), %eax
	pushl	%eax
	call	spawn_apple
	addl	$32, %esp
	movl	-4148(%ebp), %edx
	movl	-4144(%ebp), %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_putpixel
	addl	$16, %esp
.L28:
	call	gd_waitnextframe
	jmp	.L29
.L31:
	nop
	jmp	.L21
.L32:
	nop
.L21:
	movl	$0, %eax
	movl	-4(%ebp), %ecx
	leave
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
