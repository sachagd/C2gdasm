	.file	"snake.c"
	.text
	.globl	gd_draw_text
	.type	gd_draw_text, @function
gd_draw_text:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$72, %esp
#APP
# 38 "framework.c" 1
	movl %esi, %edx
movl %edi, %eax

# 0 "" 2
#NO_APP
	movl	%edx, -24(%ebp)
	movl	%eax, -28(%ebp)
	movl	-24(%ebp), %eax
	movl	%eax, -32(%ebp)
	movl	-28(%ebp), %eax
	movl	%eax, -36(%ebp)
	movl	24(%ebp), %eax
	addl	$205, %eax
	movl	%eax, -40(%ebp)
	movl	8(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	$0, -16(%ebp)
	jmp	.L2
.L5:
	movl	-16(%ebp), %eax
	leal	0(,%eax,4), %edx
	movl	16(%ebp), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, -44(%ebp)
	movl	-44(%ebp), %eax
	leal	0(,%eax,8), %edx
	movl	-32(%ebp), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, -48(%ebp)
	movl	-44(%ebp), %eax
	leal	0(,%eax,8), %edx
	movl	-32(%ebp), %eax
	addl	%edx, %eax
	movl	4(%eax), %eax
	movl	%eax, -52(%ebp)
	movl	$0, -20(%ebp)
	jmp	.L3
.L4:
	movl	-48(%ebp), %edx
	movl	-20(%ebp), %eax
	addl	%edx, %eax
	leal	0(,%eax,8), %edx
	movl	-36(%ebp), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, -56(%ebp)
	movl	-48(%ebp), %edx
	movl	-20(%ebp), %eax
	addl	%edx, %eax
	leal	0(,%eax,8), %edx
	movl	-36(%ebp), %eax
	addl	%edx, %eax
	movl	4(%eax), %eax
	movl	%eax, -60(%ebp)
	movl	-12(%ebp), %edx
	movl	-56(%ebp), %eax
	leal	(%edx,%eax), %ecx
	movl	12(%ebp), %edx
	movl	-60(%ebp), %eax
	addl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	addl	%eax, %ecx
	movl	-40(%ebp), %eax
	movl	%eax, %edx
	movl	%ecx, %eax
	call	gd_draw_pixel_simplified
	addl	$1, -20(%ebp)
.L3:
	movl	-20(%ebp), %eax
	cmpl	-52(%ebp), %eax
	jl	.L4
	addl	$4, -12(%ebp)
	addl	$1, -16(%ebp)
.L2:
	movl	-16(%ebp), %eax
	cmpl	20(%ebp), %eax
	jl	.L5
	nop
	nop
	leave
	ret
	.size	gd_draw_text, .-gd_draw_text
	.globl	gd_draw_pixel
	.type	gd_draw_pixel, @function
gd_draw_pixel:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	16(%ebp), %eax
	addl	$205, %eax
	movl	%eax, -12(%ebp)
	movl	12(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	leal	(%edx,%eax), %ecx
	movl	-12(%ebp), %eax
	movl	%eax, %edx
	movl	%ecx, %eax
	call	gd_draw_pixel_simplified
	nop
	leave
	ret
	.size	gd_draw_pixel, .-gd_draw_pixel
	.type	on_snake_circ, @function
on_snake_circ:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	$0, -4(%ebp)
	jmp	.L8
.L11:
	movl	12(%ebp), %eax
	subl	-4(%ebp), %eax
	addl	$512, %eax
	cltd
	shrl	$23, %edx
	addl	%edx, %eax
	andl	$511, %eax
	subl	%edx, %eax
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	leal	0(,%eax,8), %edx
	movl	8(%ebp), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	cmpl	%eax, 20(%ebp)
	jne	.L9
	movl	-8(%ebp), %eax
	leal	0(,%eax,8), %edx
	movl	8(%ebp), %eax
	addl	%edx, %eax
	movl	4(%eax), %eax
	cmpl	%eax, 24(%ebp)
	jne	.L9
	movl	$1, %eax
	jmp	.L10
.L9:
	addl	$1, -4(%ebp)
.L8:
	movl	-4(%ebp), %eax
	cmpl	16(%ebp), %eax
	jl	.L11
	movl	$0, %eax
.L10:
	leave
	ret
	.size	on_snake_circ, .-on_snake_circ
	.type	spawn_apple, @function
spawn_apple:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
.L13:
	movl	$80, %eax
	call	gd_randint
	movl	20(%ebp), %edx
	movl	%eax, (%edx)
	movl	$50, %eax
	call	gd_randint
	movl	24(%ebp), %edx
	movl	%eax, (%edx)
	movl	24(%ebp), %eax
	movl	(%eax), %edx
	movl	20(%ebp), %eax
	movl	(%eax), %eax
	subl	$12, %esp
	pushl	%edx
	pushl	%eax
	pushl	16(%ebp)
	pushl	12(%ebp)
	pushl	8(%ebp)
	call	on_snake_circ
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L13
	nop
	nop
	leave
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
	subl	$100, %esp
#APP
# 34 "snake.c" 1
	pushl $9
pushl $240
pushl $7
pushl $233
pushl $9
pushl $224
pushl $11
pushl $213
pushl $9
pushl $204
pushl $11
pushl $193
pushl $7
pushl $186
pushl $9
pushl $177
pushl $12
pushl $165
pushl $11
pushl $154
pushl $10
pushl $144
pushl $12
pushl $132
pushl $13
pushl $119
pushl $11
pushl $108
pushl $7
pushl $101
pushl $9
pushl $92
pushl $8
pushl $84
pushl $9
pushl $75
pushl $11
pushl $64
pushl $9
pushl $55
pushl $8
pushl $47
pushl $10
pushl $37
pushl $10
pushl $27
pushl $7
pushl $20
pushl $10
pushl $10
pushl $10
pushl $0
movl %esp, %esi
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $0
pushl $2
pushl $1
pushl $3
pushl $2
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $1
pushl $1
pushl $1
pushl $2
pushl $1
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $1
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $1
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $1
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $1
pushl $1
pushl $1
pushl $2
pushl $1
pushl $3
pushl $1
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $2
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $1
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $1
pushl $2
pushl $1
pushl $1
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $0
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $1
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $1
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $1
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $0
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $1
pushl $1
pushl $0
pushl $2
pushl $0
pushl $3
pushl $1
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $1
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $3
pushl $2
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $1
pushl $2
pushl $1
pushl $3
pushl $1
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $0
pushl $0
pushl $1
pushl $0
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $0
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $1
pushl $1
pushl $0
pushl $2
pushl $0
pushl $3
pushl $0
pushl $4
pushl $2
pushl $4
pushl $1
pushl $0
pushl $1
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $1
pushl $4
pushl $0
pushl $0
pushl $2
pushl $0
pushl $0
pushl $1
pushl $2
pushl $1
pushl $0
pushl $2
pushl $2
pushl $2
pushl $1
pushl $2
pushl $0
pushl $3
pushl $2
pushl $3
pushl $0
pushl $4
pushl $1
movl %esp, %edi

# 0 "" 2
#NO_APP
	movl	$7, -88(%ebp)
	movl	$4, -84(%ebp)
	movl	$11, -80(%ebp)
	movl	$11, -76(%ebp)
	movl	$14, -72(%ebp)
	movl	$22, -68(%ebp)
	movl	$14, -64(%ebp)
	movl	$17, -60(%ebp)
	movl	$11, -56(%ebp)
	movl	$3, -52(%ebp)
	subl	$12, %esp
	pushl	$1
	pushl	$10
	leal	-88(%ebp), %eax
	pushl	%eax
	pushl	$10
	pushl	$10
	call	gd_draw_text
	addl	$32, %esp
	movl	$2, -12(%ebp)
	movl	$3, -16(%ebp)
	movl	$1, -20(%ebp)
	movl	$0, -24(%ebp)
	movl	$38, -4184(%ebp)
	movl	$25, -4180(%ebp)
	movl	$39, -4176(%ebp)
	movl	$25, -4172(%ebp)
	movl	$40, -4168(%ebp)
	movl	$25, -4164(%ebp)
	subl	$12, %esp
	leal	-4192(%ebp), %eax
	pushl	%eax
	leal	-4188(%ebp), %eax
	pushl	%eax
	pushl	-16(%ebp)
	pushl	-12(%ebp)
	leal	-4184(%ebp), %eax
	pushl	%eax
	call	spawn_apple
	addl	$32, %esp
	movl	$0, -28(%ebp)
	jmp	.L15
.L16:
	movl	-28(%ebp), %eax
	movl	-4180(%ebp,%eax,8), %edx
	movl	-28(%ebp), %eax
	movl	-4184(%ebp,%eax,8), %eax
	subl	$4, %esp
	pushl	$1
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
	addl	$16, %esp
	addl	$1, -28(%ebp)
.L15:
	movl	-28(%ebp), %eax
	cmpl	-16(%ebp), %eax
	jl	.L16
	movl	-4192(%ebp), %edx
	movl	-4188(%ebp), %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
	addl	$16, %esp
.L29:
	call	gd_up_pressed
	testl	%eax, %eax
	je	.L17
	cmpl	$0, -24(%ebp)
	jne	.L17
	movl	$0, -20(%ebp)
	movl	$1, -24(%ebp)
	jmp	.L18
.L17:
	call	gd_w_pressed
	testl	%eax, %eax
	je	.L19
	cmpl	$0, -24(%ebp)
	jne	.L19
	movl	$0, -20(%ebp)
	movl	$-1, -24(%ebp)
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
	movl	-4184(%ebp,%eax,8), %edx
	movl	-20(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -32(%ebp)
	movl	-12(%ebp), %eax
	movl	-4180(%ebp,%eax,8), %edx
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
	leal	-4184(%ebp), %eax
	pushl	%eax
	call	on_snake_circ
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L31
	movl	-4188(%ebp), %eax
	cmpl	%eax, -32(%ebp)
	jne	.L23
	movl	-4192(%ebp), %eax
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
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	movl	-12(%ebp), %eax
	subl	-44(%ebp), %eax
	addl	$512, %eax
	cltd
	shrl	$23, %edx
	addl	%edx, %eax
	andl	$511, %eax
	subl	%edx, %eax
	movl	%eax, -48(%ebp)
	movl	-48(%ebp), %eax
	movl	-4180(%ebp,%eax,8), %edx
	movl	-48(%ebp), %eax
	movl	-4184(%ebp,%eax,8), %eax
	subl	$4, %esp
	pushl	$0
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
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
	movl	%edx, -4184(%ebp,%eax,8)
	movl	-12(%ebp), %eax
	movl	-36(%ebp), %edx
	movl	%edx, -4180(%ebp,%eax,8)
	subl	$4, %esp
	pushl	$1
	pushl	-36(%ebp)
	pushl	-32(%ebp)
	call	gd_draw_pixel
	addl	$16, %esp
	cmpl	$0, -40(%ebp)
	je	.L28
	subl	$12, %esp
	leal	-4192(%ebp), %eax
	pushl	%eax
	leal	-4188(%ebp), %eax
	pushl	%eax
	pushl	-16(%ebp)
	pushl	-12(%ebp)
	leal	-4184(%ebp), %eax
	pushl	%eax
	call	spawn_apple
	addl	$32, %esp
	movl	-4192(%ebp), %edx
	movl	-4188(%ebp), %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
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
