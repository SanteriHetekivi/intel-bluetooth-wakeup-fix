<#
.SYNOPSIS
    Re-enable device.

.DESCRIPTION
    Gets device and if it's status is not OK disables and enables it.

.NOTES
    Filename: script.ps1
    Author: Santeri Hetekivi
    Modified date: 2022-02-24
#>

# Bind for -Verbose to work.
[CmdletBinding()] param ()

try {
    Write-Verbose "Re-enabling device."

    # Class of device to re-enable.
    Set-Variable DEVICE_CLASS -Option Constant -Value "Bluetooth"
    Write-Verbose "Class: $DEVICE_CLASS"

    # Friendly name for device to re-enable.
    Set-Variable DEVICE_FRIENDLY_NAME -Option Constant -Value "Intel(R) Wireless Bluetooth(R)"
    Write-Verbose "FriendlyName: $DEVICE_FRIENDLY_NAME"

    # Device status consts.
    Set-Variable STATUS_OK -Option Constant -Value "OK"
    Set-Variable STATUS_ERROR -Option Constant -Value "ERROR"

    # Get device or $null if none found.
    function Get-Device {
        Write-Verbose "Getting device..."
        # Get devices.
        [CimInstance[]]$Devices = Get-PnpDevice -PresentOnly -Class "$DEVICE_CLASS" -FriendlyName "$DEVICE_FRIENDLY_NAME"
    
        # Get devices count.
        [int] $DevicesCount = $Devices.Length
        Write-Verbose "$DevicesCount devices found!"

        # Only one device found.
        if ($DevicesCount -eq 1) {
            # Return it.
            return $Devices[0]
        }
        # No devices found.
        elseif ($DevicesCount -eq 0) {
            throw "Device for class $DEVICE_CLASS devices, friendly name $DEVICE_FRIENDLY_NAME and status $Status not found!"
        }
        # Unsupported number of devices found.
        else {
            throw "Found $DevicesCount devices for $DEVICE_CLASS, friendly name $DEVICE_FRIENDLY_NAME and status $Status!"
        }

        <#
            .SYNOPSIS
            Get device.

            .DESCRIPTION
            Get device with defined consts.
            Throws exception if not exactly one device found.

            .INPUTS
            None.

            .OUTPUTS
            CimInstance Found device.
        #>
    }

    # Get device.
    $Device = Get-Device
    # Checking that device is not already working.
    if ($Device.Status -eq $STATUS_OK) {
        # Device is working so nothing to do here!
        Write-Verbose "Device already working!"
        Exit 0
    }
    Write-Verbose "Device not already working!"

    # Get ID of the device.
    $DeviceID = $Device.InstanceID
    Remove-Variable -Name Device
    Write-Verbose "DeviceID: $DeviceID"

    # Disable device.
    Write-Verbose "Disabling device..."
    [Int32]$WMI = Disable-PnpDevice -InstanceID $DeviceID -Confirm:$false -ErrorAction Stop
    if ($WMI -ne 0) {
        throw "Disabling device $DEVICE_FRIENDLY_NAME with ID $DeviceID failed with code $WMI!"
    }
    Write-Verbose "Disabled!"

    # Enable device.
    Write-Verbose "Enabling device..."
    [Int32]$WMI = Enable-PnpDevice -InstanceID $DeviceID -Confirm:$false -ErrorAction Stop
    if ($WMI -ne 0) {
        throw "Disabling device $DEVICE_FRIENDLY_NAME with ID $DeviceID failed with code $WMI!"
    }
    Write-Verbose "Enabled!"
    Remove-Variable -Name DeviceID
    Remove-Variable -Name WMI

    # Check that device is now working.
    Write-Verbose "Checking that device is found with $STATUS_OK status..."
    if ((Get-Device).Status -ne $STATUS_OK) {
        throw "Device $DEVICE_FRIENDLY_NAME in status $STATUS_OK not found!"
    }

    # Device is now working.
    Write-Verbose "Device working!"
    Exit 0
}
catch {
    throw $_
}
Exit 1
