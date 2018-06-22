
<#
.SYNOPSIS
Show containers and images in a single command with special color highlighting
#>

if (!(Test-Elevated (Split-Path -Leaf $PSCommandPath) -warn)) { return }

$e = [char]27

Write-Host
Write-Host 'docker ps -a' -ForegroundColor DarkYellow

$format = '{ ~id~: ~{{.ID}}~, ~names~: ~{{.Names}}~, ~image~: ~{{.Image}}~, ~status~: ~{{.Status}}~, ~ports~: ~{{.Ports}}~ }'
$ps = ((docker ps -a --format $format --no-trunc) -join ',').Replace('~', '"')
$ps = '{{ "containers": [ {0} ] }}' -f $ps | ConvertFrom-Json
$ps.containers | % { $_.id = $_.id.Substring(0, 12) }

$ps.containers | Format-Table id,
	@{
		Label = 'name'
		Expression = {
			if ($_.status -match '^Up') { $color = '92' } else { $color = '90' }
			"$e[{0}m{1}$e[0m" -f $color,$_.names
		}
	},
	@{
		Label = 'image'
		Expression = {
			if ($_.image -match '^Waters') { $color = '94' } else { $color = '96' }
			"$e[{0}m{1}$e[0m" -f $color,$_.image
		}
	},
	status,ports

Write-Host 'docker images' -ForegroundColor DarkYellow

$format = '{ ~repository~: ~{{.Repository}}~, ~tag~: ~{{.Tag}}~, ~id~: ~{{.ID}}~, ~created~: ~{{.CreatedSince}}~, ~size~: ~{{.Size}}~ }'
$im = ((docker images --format $format) -join ',').Replace('~', '"')
$im = '{{ "images": [ {0} ] }}' -f $im | ConvertFrom-Json

$im.images | Format-Table @{
		Label='repository'
		Expression = {
			if ($_.repository -eq '<none>') { $color = '90' }
			elseif ($_.repository -match '^Waters') { $color = '94' }
			else { $color = '96' }
			"$e[{0}m{1}$e[0m" -f $color,$_.repository
		}
	},
	tag,id,created,size
