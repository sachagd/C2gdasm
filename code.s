	.file	"code.c"
	.text
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
	.globl	gd_draw_rect
	.type	gd_draw_rect, @function
gd_draw_rect:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	24(%ebp), %eax
	addl	$205, %eax
	movl	%eax, -20(%ebp)
	movl	$0, -12(%ebp)
	jmp	.L3
.L6:
	movl	$0, -16(%ebp)
	jmp	.L4
.L5:
	movl	8(%ebp), %edx
	movl	-12(%ebp), %eax
	leal	(%edx,%eax), %ecx
	movl	12(%ebp), %edx
	movl	-16(%ebp), %eax
	addl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	addl	%eax, %ecx
	movl	-20(%ebp), %eax
	movl	%eax, %edx
	movl	%ecx, %eax
	call	gd_draw_pixel_simplified
	addl	$1, -16(%ebp)
.L4:
	movl	-16(%ebp), %eax
	cmpl	20(%ebp), %eax
	jl	.L5
	addl	$1, -12(%ebp)
.L3:
	movl	-12(%ebp), %eax
	cmpl	16(%ebp), %eax
	jl	.L6
	nop
	nop
	leave
	ret
	.size	gd_draw_rect, .-gd_draw_rect
	.globl	piece_block
	.type	piece_block, @function
piece_block:
	pushl	%ebp
	movl	%esp, %ebp
	cmpl	$0, 8(%ebp)
	jne	.L8
	cmpl	$0, 12(%ebp)
	je	.L9
	cmpl	$2, 12(%ebp)
	jne	.L10
.L9:
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	movl	20(%ebp), %eax
	movl	16(%ebp), %edx
	movl	%edx, (%eax)
	jmp	.L7
.L10:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	16(%ebp), %edx
	movl	%edx, (%eax)
	jmp	.L7
.L8:
	cmpl	$1, 8(%ebp)
	jne	.L13
	cmpl	$0, 16(%ebp)
	jne	.L14
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L14:
	cmpl	$1, 16(%ebp)
	jne	.L16
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L16:
	cmpl	$2, 16(%ebp)
	jne	.L17
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L17:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L13:
	cmpl	$2, 8(%ebp)
	jne	.L18
	cmpl	$0, 12(%ebp)
	jne	.L19
	cmpl	$0, 16(%ebp)
	jne	.L20
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L20:
	cmpl	$1, 16(%ebp)
	jne	.L22
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L22:
	cmpl	$2, 16(%ebp)
	jne	.L23
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L23:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L19:
	cmpl	$1, 12(%ebp)
	jne	.L24
	cmpl	$0, 16(%ebp)
	jne	.L25
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L25:
	cmpl	$1, 16(%ebp)
	jne	.L26
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L26:
	cmpl	$2, 16(%ebp)
	jne	.L27
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L27:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L24:
	cmpl	$2, 12(%ebp)
	jne	.L28
	cmpl	$0, 16(%ebp)
	jne	.L29
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L29:
	cmpl	$1, 16(%ebp)
	jne	.L30
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L30:
	cmpl	$2, 16(%ebp)
	jne	.L31
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L31:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L28:
	cmpl	$0, 16(%ebp)
	jne	.L32
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L32:
	cmpl	$1, 16(%ebp)
	jne	.L33
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L33:
	cmpl	$2, 16(%ebp)
	jne	.L34
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L34:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L18:
	cmpl	$3, 8(%ebp)
	jne	.L35
	cmpl	$0, 12(%ebp)
	je	.L36
	cmpl	$2, 12(%ebp)
	jne	.L37
.L36:
	cmpl	$0, 16(%ebp)
	jne	.L38
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L42
.L38:
	cmpl	$1, 16(%ebp)
	jne	.L40
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L42
.L40:
	cmpl	$2, 16(%ebp)
	jne	.L41
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L42
.L41:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L42
.L37:
	cmpl	$0, 16(%ebp)
	jne	.L43
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L43:
	cmpl	$1, 16(%ebp)
	jne	.L44
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L44:
	cmpl	$2, 16(%ebp)
	jne	.L45
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L45:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L42:
	jmp	.L7
.L35:
	cmpl	$4, 8(%ebp)
	jne	.L46
	cmpl	$0, 12(%ebp)
	je	.L47
	cmpl	$2, 12(%ebp)
	jne	.L48
.L47:
	cmpl	$0, 16(%ebp)
	jne	.L49
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L53
.L49:
	cmpl	$1, 16(%ebp)
	jne	.L51
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L53
.L51:
	cmpl	$2, 16(%ebp)
	jne	.L52
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L53
.L52:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L53
.L48:
	cmpl	$0, 16(%ebp)
	jne	.L54
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L54:
	cmpl	$1, 16(%ebp)
	jne	.L55
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L55:
	cmpl	$2, 16(%ebp)
	jne	.L56
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L56:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L53:
	jmp	.L7
.L46:
	cmpl	$5, 8(%ebp)
	jne	.L57
	cmpl	$0, 12(%ebp)
	jne	.L58
	cmpl	$0, 16(%ebp)
	jne	.L59
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L59:
	cmpl	$1, 16(%ebp)
	jne	.L61
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L61:
	cmpl	$2, 16(%ebp)
	jne	.L62
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L62:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L58:
	cmpl	$1, 12(%ebp)
	jne	.L63
	cmpl	$0, 16(%ebp)
	jne	.L64
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L64:
	cmpl	$1, 16(%ebp)
	jne	.L65
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L65:
	cmpl	$2, 16(%ebp)
	jne	.L66
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L66:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L63:
	cmpl	$2, 12(%ebp)
	jne	.L67
	cmpl	$0, 16(%ebp)
	jne	.L68
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L68:
	cmpl	$1, 16(%ebp)
	jne	.L69
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L69:
	cmpl	$2, 16(%ebp)
	jne	.L70
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L70:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L67:
	cmpl	$0, 16(%ebp)
	jne	.L71
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L71:
	cmpl	$1, 16(%ebp)
	jne	.L72
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L72:
	cmpl	$2, 16(%ebp)
	jne	.L73
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L73:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L57:
	cmpl	$0, 12(%ebp)
	jne	.L74
	cmpl	$0, 16(%ebp)
	jne	.L75
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L75:
	cmpl	$1, 16(%ebp)
	jne	.L76
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L76:
	cmpl	$2, 16(%ebp)
	jne	.L77
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L77:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L74:
	cmpl	$1, 12(%ebp)
	jne	.L78
	cmpl	$0, 16(%ebp)
	jne	.L79
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L79:
	cmpl	$1, 16(%ebp)
	jne	.L80
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L80:
	cmpl	$2, 16(%ebp)
	jne	.L81
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L81:
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L78:
	cmpl	$2, 12(%ebp)
	jne	.L82
	cmpl	$0, 16(%ebp)
	jne	.L83
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L83:
	cmpl	$1, 16(%ebp)
	jne	.L84
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L84:
	cmpl	$2, 16(%ebp)
	jne	.L85
	movl	20(%ebp), %eax
	movl	$2, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L85:
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
	jmp	.L7
.L82:
	cmpl	$0, 16(%ebp)
	jne	.L86
	movl	20(%ebp), %eax
	movl	$0, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L86:
	cmpl	$1, 16(%ebp)
	jne	.L87
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$0, (%eax)
	jmp	.L7
.L87:
	cmpl	$2, 16(%ebp)
	jne	.L88
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$1, (%eax)
	jmp	.L7
.L88:
	movl	20(%ebp), %eax
	movl	$1, (%eax)
	movl	24(%ebp), %eax
	movl	$2, (%eax)
.L7:
	popl	%ebp
	ret
	.size	piece_block, .-piece_block
	.globl	can_place
	.type	can_place, @function
can_place:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$32, %esp
	movl	$0, -4(%ebp)
	jmp	.L90
.L96:
	leal	-20(%ebp), %eax
	pushl	%eax
	leal	-16(%ebp), %eax
	pushl	%eax
	pushl	-4(%ebp)
	pushl	16(%ebp)
	pushl	12(%ebp)
	call	piece_block
	addl	$20, %esp
	movl	-16(%ebp), %edx
	movl	20(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -8(%ebp)
	movl	-20(%ebp), %edx
	movl	24(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -12(%ebp)
	cmpl	$0, -8(%ebp)
	js	.L91
	cmpl	$9, -8(%ebp)
	jg	.L91
	cmpl	$0, -12(%ebp)
	js	.L91
	cmpl	$19, -12(%ebp)
	jle	.L92
.L91:
	movl	$0, %eax
	jmp	.L95
.L92:
	movl	-12(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	addl	%eax, %edx
	movl	-8(%ebp), %eax
	movl	(%edx,%eax,4), %eax
	testl	%eax, %eax
	je	.L94
	movl	$0, %eax
	jmp	.L95
.L94:
	addl	$1, -4(%ebp)
.L90:
	cmpl	$3, -4(%ebp)
	jle	.L96
	movl	$1, %eax
.L95:
	leave
	ret
	.size	can_place, .-can_place
	.globl	lock_piece
	.type	lock_piece, @function
lock_piece:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	$0, -4(%ebp)
	jmp	.L98
.L99:
	leal	-12(%ebp), %eax
	pushl	%eax
	leal	-8(%ebp), %eax
	pushl	%eax
	pushl	-4(%ebp)
	pushl	16(%ebp)
	pushl	12(%ebp)
	call	piece_block
	addl	$20, %esp
	movl	-12(%ebp), %edx
	movl	24(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	addl	%edx, %eax
	movl	-8(%ebp), %ecx
	movl	20(%ebp), %edx
	addl	%ecx, %edx
	movl	$1, (%eax,%edx,4)
	addl	$1, -4(%ebp)
.L98:
	cmpl	$3, -4(%ebp)
	jle	.L99
	nop
	nop
	leave
	ret
	.size	lock_piece, .-lock_piece
	.globl	clear_full_lines
	.type	clear_full_lines, @function
clear_full_lines:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$32, %esp
	movl	$19, -8(%ebp)
	jmp	.L101
.L113:
	movl	$1, -12(%ebp)
	movl	$0, -16(%ebp)
	jmp	.L102
.L105:
	movl	-8(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	addl	%eax, %edx
	movl	-16(%ebp), %eax
	movl	(%edx,%eax,4), %eax
	testl	%eax, %eax
	jne	.L103
	movl	$0, -12(%ebp)
	jmp	.L104
.L103:
	addl	$1, -16(%ebp)
.L102:
	cmpl	$9, -16(%ebp)
	jle	.L105
.L104:
	cmpl	$0, -12(%ebp)
	je	.L106
	movl	-8(%ebp), %eax
	movl	%eax, -20(%ebp)
	jmp	.L107
.L110:
	movl	$0, -24(%ebp)
	jmp	.L108
.L109:
	movl	-20(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	leal	-40(%eax), %edx
	movl	8(%ebp), %eax
	leal	(%edx,%eax), %ebx
	movl	-20(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	leal	(%edx,%eax), %ecx
	movl	-24(%ebp), %eax
	movl	(%ebx,%eax,4), %edx
	movl	-24(%ebp), %eax
	movl	%edx, (%ecx,%eax,4)
	addl	$1, -24(%ebp)
.L108:
	cmpl	$9, -24(%ebp)
	jle	.L109
	subl	$1, -20(%ebp)
.L107:
	cmpl	$0, -20(%ebp)
	jg	.L110
	movl	$0, -28(%ebp)
	jmp	.L111
.L112:
	movl	8(%ebp), %eax
	movl	-28(%ebp), %edx
	movl	$0, (%eax,%edx,4)
	addl	$1, -28(%ebp)
.L111:
	cmpl	$9, -28(%ebp)
	jle	.L112
	addl	$1, -8(%ebp)
.L106:
	subl	$1, -8(%ebp)
.L101:
	cmpl	$0, -8(%ebp)
	jns	.L113
	nop
	nop
	movl	-4(%ebp), %ebx
	leave
	ret
	.size	clear_full_lines, .-clear_full_lines
	.globl	draw_locked
	.type	draw_locked, @function
draw_locked:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	$0, -12(%ebp)
	jmp	.L115
.L119:
	movl	$0, -16(%ebp)
	jmp	.L116
.L118:
	movl	-12(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$3, %eax
	movl	%eax, %edx
	movl	8(%ebp), %eax
	addl	%eax, %edx
	movl	-16(%ebp), %eax
	movl	(%edx,%eax,4), %eax
	testl	%eax, %eax
	je	.L117
	movl	16(%ebp), %edx
	movl	-12(%ebp), %eax
	addl	%eax, %edx
	movl	12(%ebp), %ecx
	movl	-16(%ebp), %eax
	addl	%ecx, %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
	addl	$16, %esp
.L117:
	addl	$1, -16(%ebp)
.L116:
	cmpl	$9, -16(%ebp)
	jle	.L118
	addl	$1, -12(%ebp)
.L115:
	cmpl	$19, -12(%ebp)
	jle	.L119
	nop
	nop
	leave
	ret
	.size	draw_locked, .-draw_locked
	.globl	draw_piece
	.type	draw_piece, @function
draw_piece:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	$0, -12(%ebp)
	jmp	.L121
.L123:
	leal	-28(%ebp), %eax
	pushl	%eax
	leal	-24(%ebp), %eax
	pushl	%eax
	pushl	-12(%ebp)
	pushl	12(%ebp)
	pushl	8(%ebp)
	call	piece_block
	addl	$20, %esp
	movl	-24(%ebp), %edx
	movl	16(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -16(%ebp)
	movl	-28(%ebp), %edx
	movl	20(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -20(%ebp)
	cmpl	$0, -16(%ebp)
	js	.L122
	cmpl	$9, -16(%ebp)
	jg	.L122
	cmpl	$0, -20(%ebp)
	js	.L122
	cmpl	$19, -20(%ebp)
	jg	.L122
	movl	28(%ebp), %edx
	movl	-20(%ebp), %eax
	addl	%eax, %edx
	movl	24(%ebp), %ecx
	movl	-16(%ebp), %eax
	addl	%ecx, %eax
	subl	$4, %esp
	pushl	$2
	pushl	%edx
	pushl	%eax
	call	gd_draw_pixel
	addl	$16, %esp
.L122:
	addl	$1, -12(%ebp)
.L121:
	cmpl	$3, -12(%ebp)
	jle	.L123
	nop
	nop
	leave
	ret
	.size	draw_piece, .-draw_piece
	.globl	main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	subl	$932, %esp
	movl	$10, -68(%ebp)
	movl	$20, -72(%ebp)
	movl	-68(%ebp), %eax
	addl	$2, %eax
	movl	%eax, -76(%ebp)
	movl	-72(%ebp), %eax
	addl	$2, %eax
	movl	%eax, -80(%ebp)
	movl	$80, %eax
	subl	-76(%ebp), %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	movl	%eax, -84(%ebp)
	movl	$50, %eax
	subl	-80(%ebp), %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	movl	%eax, -88(%ebp)
	movl	-84(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -92(%ebp)
	movl	-88(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -96(%ebp)
	movl	$0, -12(%ebp)
	jmp	.L125
.L128:
	movl	$0, -16(%ebp)
	jmp	.L126
.L127:
	movl	-12(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	-16(%ebp), %edx
	addl	%edx, %eax
	movl	$0, -928(%ebp,%eax,4)
	addl	$1, -16(%ebp)
.L126:
	cmpl	$9, -16(%ebp)
	jle	.L127
	addl	$1, -12(%ebp)
.L125:
	cmpl	$19, -12(%ebp)
	jle	.L128
	subl	$12, %esp
	pushl	$1
	pushl	-80(%ebp)
	pushl	-76(%ebp)
	pushl	-88(%ebp)
	pushl	-84(%ebp)
	call	gd_draw_rect
	addl	$32, %esp
	subl	$12, %esp
	pushl	$0
	pushl	-72(%ebp)
	pushl	-68(%ebp)
	pushl	-96(%ebp)
	pushl	-92(%ebp)
	call	gd_draw_rect
	addl	$32, %esp
	movl	$7, %eax
	call	gd_randint
	movl	%eax, -20(%ebp)
	movl	$0, -24(%ebp)
	movl	$3, -28(%ebp)
	movl	$0, -32(%ebp)
	movl	$0, -36(%ebp)
	movl	$0, -40(%ebp)
	movl	$0, -44(%ebp)
	movl	$0, -48(%ebp)
	movl	$0, -52(%ebp)
	movl	$0, -56(%ebp)
	movl	$20, -100(%ebp)
.L148:
	call	gd_a_pressed
	movl	%eax, -104(%ebp)
	call	gd_d_pressed
	movl	%eax, -108(%ebp)
	call	gd_left_pressed
	movl	%eax, -112(%ebp)
	call	gd_right_pressed
	movl	%eax, -116(%ebp)
	call	gd_w_pressed
	movl	%eax, -120(%ebp)
	cmpl	$0, -104(%ebp)
	je	.L129
	cmpl	$0, -36(%ebp)
	jne	.L129
	cmpl	$0, -24(%ebp)
	je	.L130
	movl	-24(%ebp), %eax
	subl	$1, %eax
	jmp	.L131
.L130:
	movl	$3, %eax
.L131:
	movl	%eax, -124(%ebp)
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-124(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L129
	movl	-124(%ebp), %eax
	movl	%eax, -24(%ebp)
.L129:
	cmpl	$0, -108(%ebp)
	je	.L132
	cmpl	$0, -40(%ebp)
	jne	.L132
	cmpl	$3, -24(%ebp)
	je	.L133
	movl	-24(%ebp), %eax
	addl	$1, %eax
	jmp	.L134
.L133:
	movl	$0, %eax
.L134:
	movl	%eax, -128(%ebp)
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-128(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L132
	movl	-128(%ebp), %eax
	movl	%eax, -24(%ebp)
.L132:
	cmpl	$0, -112(%ebp)
	je	.L135
	cmpl	$0, -44(%ebp)
	jne	.L135
	movl	-28(%ebp), %eax
	subl	$1, %eax
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	%eax
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L135
	subl	$1, -28(%ebp)
.L135:
	cmpl	$0, -116(%ebp)
	je	.L136
	cmpl	$0, -48(%ebp)
	jne	.L136
	movl	-28(%ebp), %eax
	addl	$1, %eax
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	%eax
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L136
	addl	$1, -28(%ebp)
.L136:
	cmpl	$0, -120(%ebp)
	je	.L137
	cmpl	$0, -52(%ebp)
	jne	.L137
	jmp	.L138
.L139:
	addl	$1, -32(%ebp)
.L138:
	movl	-32(%ebp), %eax
	addl	$1, %eax
	subl	$12, %esp
	pushl	%eax
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L139
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	lock_piece
	addl	$32, %esp
	subl	$12, %esp
	leal	-928(%ebp), %eax
	pushl	%eax
	call	clear_full_lines
	addl	$16, %esp
	movl	$7, %eax
	call	gd_randint
	movl	%eax, -20(%ebp)
	movl	$0, -24(%ebp)
	movl	$3, -28(%ebp)
	movl	$0, -32(%ebp)
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L151
	movl	$0, -56(%ebp)
	jmp	.L142
.L137:
	addl	$1, -56(%ebp)
	movl	-56(%ebp), %eax
	cmpl	-100(%ebp), %eax
	jl	.L142
	movl	$0, -56(%ebp)
	movl	-32(%ebp), %eax
	addl	$1, %eax
	subl	$12, %esp
	pushl	%eax
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	je	.L143
	addl	$1, -32(%ebp)
	jmp	.L142
.L143:
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	lock_piece
	addl	$32, %esp
	subl	$12, %esp
	leal	-928(%ebp), %eax
	pushl	%eax
	call	clear_full_lines
	addl	$16, %esp
	movl	$7, %eax
	call	gd_randint
	movl	%eax, -20(%ebp)
	movl	$0, -24(%ebp)
	movl	$3, -28(%ebp)
	movl	$0, -32(%ebp)
	subl	$12, %esp
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	can_place
	addl	$32, %esp
	testl	%eax, %eax
	jne	.L142
	movl	$0, -60(%ebp)
	jmp	.L144
.L147:
	movl	$0, -64(%ebp)
	jmp	.L145
.L146:
	movl	-60(%ebp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	-64(%ebp), %edx
	addl	%edx, %eax
	movl	$0, -928(%ebp,%eax,4)
	addl	$1, -64(%ebp)
.L145:
	cmpl	$9, -64(%ebp)
	jle	.L146
	addl	$1, -60(%ebp)
.L144:
	cmpl	$19, -60(%ebp)
	jle	.L147
.L142:
	movl	-104(%ebp), %eax
	movl	%eax, -36(%ebp)
	movl	-108(%ebp), %eax
	movl	%eax, -40(%ebp)
	movl	-112(%ebp), %eax
	movl	%eax, -44(%ebp)
	movl	-116(%ebp), %eax
	movl	%eax, -48(%ebp)
	movl	-120(%ebp), %eax
	movl	%eax, -52(%ebp)
	subl	$12, %esp
	pushl	$0
	pushl	-72(%ebp)
	pushl	-68(%ebp)
	pushl	-96(%ebp)
	pushl	-92(%ebp)
	call	gd_draw_rect
	addl	$32, %esp
	subl	$4, %esp
	pushl	-96(%ebp)
	pushl	-92(%ebp)
	leal	-928(%ebp), %eax
	pushl	%eax
	call	draw_locked
	addl	$16, %esp
	subl	$8, %esp
	pushl	-96(%ebp)
	pushl	-92(%ebp)
	pushl	-32(%ebp)
	pushl	-28(%ebp)
	pushl	-24(%ebp)
	pushl	-20(%ebp)
	call	draw_piece
	addl	$32, %esp
	call	gd_waitnextframe
	jmp	.L148
.L151:
	nop
	movl	$0, %eax
	movl	-4(%ebp), %ecx
	leave
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
