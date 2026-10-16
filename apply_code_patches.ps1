# Re-applies manual patches to generated code AFTER codegen (run at end of build_release.bat).
# Codegen regenerates *.cpp whenever the manifest changes; this script pins fixes
# that codegen can't express. Idempotent: safe to run repeatedly.
$ErrorActionPreference = "Continue"

$fixes = @(
    # FIX 1: post-race black screen (Xenia patch "Fix blackscreen after returning to menu"
    # by Gliniak, title 555307EE, guest 0x8218E4EC: cmpwi loading-check cycles 0x3C -> 0x1A).
    # In sub_8218E420 (only change inside that host function).
          @{ name = "FIX1-loader-threshold"
       path = "D:\ITC-Recomp\generated\default\itc_recomp_recomp.40.cpp"
       marker = "Xenia black-screen fix (guest 0x8218E4EC)"
       search = '// cmplwi cr6,r11,60\r?\n\s*ctx\.cr6\.compare<uint32_t>\(ctx\.r11\.u32, 60, ctx\.xer\);'
       replace = '// cmplwi cr6,r11,60 (Xenia black-screen fix (guest 0x8218E4EC): patched threshold)`n`tctx.cr6.compare<uint32_t>(ctx.r11.u32, 10, ctx.xer);' }
)

$fixed = @()
foreach ($f in $fixes) {
    $p = $f.path
    if (-not (Test-Path $p)) { Write-Output ("FIX " + $f.name + " WARNING: file not found: " + $p); continue }
    $c = Get-Content $p -Raw
    if ($c -match [regex]::Escape($f.marker)) {
        Write-Output ("FIX " + $f.name + " already applied")
    } elseif ($c -match $f.search) {
        $c = [regex]::Replace($c, $f.search, $f.replace)
        Set-Content -Path $p -Value $c -NoNewline
        $fixed += $f.name
        Write-Output ("FIX " + $f.name + " applied")
    } else {
        Write-Output ("FIX " + $f.name + " WARNING: search text not found, manual review needed")
    }
}
Write-Output ("post-codegen patches applied this run: " + $fixed.Count)

