; RUN: llc < %s -march=x86-64 | FileCheck %s

declare void @bar()

define void @test1(i32* nocapture %X) nounwind {
entry:
  %tmp1 = load i32* %X, align 4
  %and = and i32 %tmp1, 255
  %cmp = icmp eq i32 %and, 47
  br i1 %cmp, label %if.then, label %if.end

if.then:
  tail call void @bar() nounwind
  br label %if.end

if.end:
  ret void
; CHECK: test1:
; CHECK: cmpb $47, (%{{rdi|rcx}})
}

define void @test2(i32 %X) nounwind {
entry:
  %and = and i32 %X, 255
  %cmp = icmp eq i32 %and, 47
  br i1 %cmp, label %if.then, label %if.end

if.then:
  tail call void @bar() nounwind
  br label %if.end

if.end:
  ret void
; CHECK: test2:
; CHECK: cmpb $47, %{{dil|cl}}
}

define void @test3(i32 %X) nounwind {
entry:
  %and = and i32 %X, 255
  %cmp = icmp eq i32 %and, 255
  br i1 %cmp, label %if.then, label %if.end

if.then:
  tail call void @bar() nounwind
  br label %if.end

if.end:
  ret void
; CHECK: test3:
; CHECK: cmpb $-1, %{{dil|cl}}
}

; PR16083
define i1 @test4(i64 %a, i32 %b) {
entry:
  %tobool = icmp ne i32 %b, 0
  br i1 %tobool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %and = and i64 0, %a
  %tobool1 = icmp ne i64 %and, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %p = phi i1 [ true, %entry ], [ %tobool1, %lor.rhs ]
  ret i1 %p
}
