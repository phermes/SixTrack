! P. Hermes for Heavy Ion SixTrack (hiSix)
module mod_hions
  
  use floatPrecision
  use parpro
  use, intrinsic :: iso_fortran_env, only : int16, int32, int64
  use mod_alloc
  use numerical_constants, only : zero, one
  
  implicit none
  
  ! initialize the variables for ion tracking
  
  ! Checking for the HION block
  logical, save :: has_hion
  
  ! Rest mass of the reference ion species
  real(kind=fPrec), save :: nucm0,nucmda
  real(kind=fPrec), save :: brhono
  
  ! ien0,ien1: ion energy entering/leaving the collimator
  real(kind=fPrec), save :: ien0, ien1
  
  ! Rest mass of the tracked ion
  real(kind=fPrec), allocatable, save :: nucm(:) !(npart)
  
  ! Relative rigidity offset
  real(kind=fPrec), allocatable, save :: moidpsv(:) !(npart)
  real(kind=fPrec), allocatable, save :: omoidpsv(:) !(npart)
  
  ! Relative mass to charge ratio
  real(kind=fPrec), allocatable, save :: mtc(:) !(npart)
  
  ! Nucleon number of the reference ion species
  integer(kind=int16), save :: aa0
  
  ! Charge multiplicity of the reference ion species
  integer(kind=int16), save :: zz0
  
  integer(kind=int16), save :: nnuc0
  integer(kind=int16), save :: nnuc1
  
  ! Nucleon number of the tracked ion
  integer(kind=int16), allocatable, save :: naa(:) !(npart)
  
  ! Charge multiplicity of the tracked ion
  integer(kind=int16), allocatable, save :: nzz(:) !(npart)
  
  ! SixTrack particle IDs
  integer, allocatable, save :: pids(:) !(npart)
  
#ifdef CR
  real(kind=fPrec),                 save :: nucmda_cr
  real(kind=fPrec),                 save :: brhono_cr
  real(kind=fPrec),                 save :: ien0_cr
  real(kind=fPrec),                 save :: ien1_cr
  integer(kind=int16),              save :: nnuc0_cr
  integer(kind=int16),              save :: nnuc1_cr
  real(kind=fPrec),    allocatable, save :: nucm_cr(:)
  real(kind=fPrec),    allocatable, save :: moidpsv_cr(:)
  real(kind=fPrec),    allocatable, save :: omoidpsv_cr(:)
  real(kind=fPrec),    allocatable, save :: mtc_cr(:)
  integer(kind=int16), allocatable, save :: naa_cr(:)
  integer(kind=int16), allocatable, save :: nzz_cr(:)
  integer,             allocatable, save :: pids_cr(:)
#endif
  
contains

subroutine mod_hions_allocate_arrays
  
  implicit none
  
  ! Rest mass of the tracked ion
  call alloc(nucm,npart,nucm0,'nucm') !(npart)
  
  ! Relative rigidity offset
  call alloc(moidpsv,npart,one,'moidpsv') !(npart)
  call alloc(omoidpsv,npart,zero,'omoidpsv') !(npart)
  
  ! Relative mass to charge ratio
  call alloc(mtc,npart,one,'mtc') !(npart)
  
  ! Nucleon number of the tracked ion
  call alloc(naa,npart,aa0,'naa') !(npart)
  
  ! Charge multiplicity of the tracked ion
  call alloc(nzz,npart,zz0,'nzz') !(npart)
  
  ! SixTrack particle IDs
  call alloc(pids,npart,0,'pids') !(npart)
  
end subroutine mod_hions_allocate_arrays

subroutine mod_hions_expand_arrays(npart_new)
  
  implicit none
  
  integer, intent(in) :: npart_new
  
  ! Rest mass of the tracked ion
  call resize(nucm,npart_new,nucm0,'nucm') !(npart)
  
  ! Relative rigidity offset
  call resize(moidpsv,npart_new,one,'moidpsv') !(npart)
  call resize(omoidpsv,npart_new,zero,'omoidpsv') !(npart)
  
  ! Relative mass to charge ratio
  call resize(mtc,npart_new,one,'mtc') !(npart)
  
  ! Nucleon number of the tracked ion
  call resize(naa,npart_new,aa0,'naa') !(npart)
  
  ! Charge multiplicity of the tracked ion
  call resize(nzz,npart_new,zz0,'nzz') !(npart)
  
  ! SixTrack particle IDs
  call resize(pids,npart_new,0,'pids') !(npart)
  
end subroutine mod_hions_expand_arrays

#ifdef CR
subroutine hions_crpoint(fileUnit, writeErr, iErro)
  
  implicit none
  
  integer, intent(in)    :: fileUnit
  logical, intent(out)   :: writeErr
  integer, intent(inout) :: iErro
  
  integer i
  
  write(fileUnit,err=10,iostat=iErro) nucmda,brhono,ien0,ien1,nnuc0,nnuc1
  write(fileUnit,err=10,iostat=iErro) (nucm(i),     i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (moidpsv(i),  i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (omoidpsv(i), i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (mtc(i),      i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (naa(i),      i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (nzz(i),      i=1, npart)
  write(fileUnit,err=10,iostat=iErro) (pids(i),     i=1, npart)
  endfile(fileUnit,iostat=iErro)
  backspace(fileUnit,iostat=iErro)
  
  return
  
10 continue
  writeErr = .true.
  
end subroutine hions_crpoint

subroutine hions_crcheck_readdata(fileUnit, readErr)
  
  use crcoall
  
  implicit none
  
  integer, intent(in)  :: fileUnit
  logical, intent(out) :: readErr
  
  integer i
  
  call alloc(nucm_cr,    npart,nucm0,"nucm_cr")
  call alloc(moidpsv_cr, npart,one,  "moidpsv_cr")
  call alloc(omoidpsv_cr,npart,zero, "omoidpsv_cr")
  call alloc(mtc_cr,     npart,one,  "mtc_cr")
  call alloc(naa_cr,     npart,aa0,  "naa_cr")
  call alloc(nzz_cr,     npart,zz0,  "nzz_cr")
  call alloc(pids_cr,    npart,0,    "pids_cr")
  
  read(fileunit,err=10,end=10) nucmda_cr,brhono_cr,ien0_cr,ien1_cr,nnuc0_cr,nnuc1_cr
  read(fileunit,err=10,end=10) (nucm_cr(i),     i=1, npart)
  read(fileunit,err=10,end=10) (moidpsv_cr(i),  i=1, npart)
  read(fileunit,err=10,end=10) (omoidpsv_cr(i), i=1, npart)
  read(fileunit,err=10,end=10) (mtc_cr(i),      i=1, npart)
  read(fileunit,err=10,end=10) (naa_cr(i),      i=1, npart)
  read(fileunit,err=10,end=10) (nzz_cr(i),      i=1, npart)
  read(fileunit,err=10,end=10) (pids_cr(i),     i=1, npart)
  
  readErr = .false.
  return
  
10 continue
  write(lout,*) "READERR in hions_crcheck; fileUnit = ",fileUnit
  write(93,*)   "READERR in hions_crcheck; fileUnit = ",fileUnit
  readErr = .true.
  
end subroutine hions_crcheck_readdata

subroutine hions_crstart
  
  implicit none
  
  nucmda = nucmda_cr
  brhono = brhono_cr
  ien0   = ien0_cr
  ien1   = ien1_cr
  nnuc0  = nnuc0_cr
  nnuc1  = nnuc1_cr
  
  nucm(1:npart)     = nucm_cr(1:npart)
  moidpsv(1:npart)  = moidpsv_cr(1:npart)
  omoidpsv(1:npart) = omoidpsv_cr(1:npart)
  mtc(1:npart)      = mtc_cr(1:npart)
  naa(1:npart)      = naa_cr(1:npart)
  nzz(1:npart)      = nzz_cr(1:npart)
  pids(1:npart)     = pids_cr(1:npart)
  
  call dealloc(nucm_cr,    "nucm_cr")
  call dealloc(moidpsv_cr, "moidpsv_cr")
  call dealloc(omoidpsv_cr,"omoidpsv_cr")
  call dealloc(mtc_cr,     "mtc_cr")
  call dealloc(naa_cr,     "naa_cr")
  call dealloc(nzz_cr,     "nzz_cr")
  call dealloc(pids_cr,    "pids_cr")
  
end subroutine hions_crstart
#endif
end module mod_hions
