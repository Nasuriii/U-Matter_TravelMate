document.addEventListener('DOMContentLoaded',()=>{
  const menus=[...document.querySelectorAll('.tm-account-menu')];
  document.addEventListener('click',event=>menus.forEach(menu=>{if(!menu.contains(event.target))menu.open=false;}));
  document.addEventListener('keydown',event=>{if(event.key==='Escape')menus.forEach(menu=>{if(menu.open){menu.open=false;menu.querySelector('summary').focus();}});});
  document.querySelectorAll('[data-fallback-image]').forEach(image=>{
    const hide=()=>{image.hidden=true;image.closest('[data-photo-frame]')?.classList.add('is-image-unavailable');};
    image.addEventListener('error',hide);if(image.complete && image.naturalWidth===0)hide();
  });
});
