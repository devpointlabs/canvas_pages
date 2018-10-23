const toggle = document.getElementById('toggle_nav')

const toggleNav = ()  => {
  const nav = document.getElementById('nav')
  nav.style.display = (nav.style.display == 'none') ? 'flex' : 'none';
}

toggle.addEventListener('click', toggleNav)

