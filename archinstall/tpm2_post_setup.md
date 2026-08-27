# Привязка LUKS тома к TPM 2.0 для UKI

## 1. Проверить LUKS UUID и TPM

```bash
lsblk -f
sudo cryptsetup luksUUID /dev/sda2
systemd-cryptenroll --tpm2-device=list
````

Запомнить:

```text
<LUKS_UUID>
```

---

## 2. Установить TPM2 userspace

```bash
sudo pacman -S tpm2-tss
```

---

## 3. Создать recovery key

```bash
sudo systemd-cryptenroll /dev/sda2 --recovery-key
```

Сохранить recovery key вне компьютера.

---

## 4. Привязать LUKS2 к TPM2

```bash
sudo systemd-cryptenroll --tpm2-device=auto dev/sda2
```

Проверить:

```bash
sudo systemd-cryptenroll /dev/sda2
```

Ожидается:

```text
0 password
1 recovery
2 tpm2
```

---

## 5. Настроить mkinitcpio

```bash
sudo nano /etc/mkinitcpio.conf
```

Поменять HOOKS:

```text
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```

---

## 6. Настроить command line для UKI

```bash
sudo nano /etc/kernel/cmdline
```

Использовать:

```text
rd.luks.name=<LUKS_UUID>=root rd.luks.options=<LUKS_UUID>=tpm2-device=auto root=/dev/mapper/root rootflags=subvol=@ rw rootfstype=btrfs
```

---

## 7. Пересобрать UKI

```bash
sudo mkinitcpio -P
```

---

## 8. Проверить command line внутри UKI

```bash
sudo objcopy \
  --dump-section .cmdline=/dev/stdout \
  /boot/EFI/Linux/arch-linux.efi
```

Должно присутствовать:

```text
rd.luks.name=<LUKS_UUID>=root
rd.luks.options=<LUKS_UUID>=tpm2-device=auto
root=/dev/mapper/root
rootflags=subvol=@
```

---

## 9. Проверить initramfs

```bash
lsinitcpio /boot/initramfs-linux.img | grep -E 'systemd-cryptsetup|sd-encrypt'
```

---

## 10. Перегенерировать GRUB

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 11. Финальная проверка

```bash
sudo systemd-cryptenroll /dev/sda2
```

Должны присутствовать:

```text
password
recovery
tpm2
```

---

## 13. Перезагрузка

```bash
sudo reboot
```