if(NOT DEFINED dir)
  message(FATAL_ERROR "dir not defined")
endif()

if(NOT DEFINED gen)
  message(FATAL_ERROR "gen not defined")
endif()

# TODO: Generalize this for other tests.
function(run_test test)
  set(top_src "${CMAKE_CURRENT_LIST_DIR}")
  set(top_bin "${dir}")
  if(EXISTS ${top_src}/${test}-result.txt)
    file(READ ${top_src}/${test}-result.txt expect_result)
    string(REGEX REPLACE "\n+$" "" expect_result "${expect_result}")
  else()
    set(expect_result 0)
  endif()
  foreach(o out err)
    if(EXISTS ${top_src}/${test}-std${o}.txt)
      file(READ ${top_src}/${test}-std${o}.txt expect_std${o})
      string(REGEX REPLACE "\n+$" "" expect_std${o} "${expect_std${o}}")
    else()
      unset(expect_std${o})
    endif()
  endforeach()
  set(source_dir "${top_src}")
  set(binary_dir "${top_bin}/${test}-build")
  file(REMOVE_RECURSE "${binary_dir}")
  file(MAKE_DIRECTORY "${binary_dir}")
  execute_process(
    COMMAND ${CMAKE_COMMAND} "${source_dir}" -G "${gen}" -DTEST=${test}
    WORKING_DIRECTORY "${binary_dir}"
    OUTPUT_VARIABLE actual_stdout
    ERROR_VARIABLE actual_stderr
    RESULT_VARIABLE actual_result
    )
  set(msg "")
  if(NOT "${actual_result}" STREQUAL "${expect_result}")
    set(msg "${msg}Result is [${actual_result}], not [${expect_result}].\n")
  endif()
  foreach(o out err)
    string(REGEX REPLACE "\n+$" "" actual_std${o} "${actual_std${o}}")
    set(expect_${o} "")
    if(DEFINED expect_std${o})
      if(NOT "${actual_std${o}}" MATCHES "${expect_std${o}}")
        string(REGEX REPLACE "\n" "\n expect-${o}> " expect_${o}
          " expect-${o}> ${expect_std${o}}")
        set(expect_${o} "Expected std${o} to match:\n${expect_${o}}\n")
        set(msg "${msg}std${o} does not match that expected.\n")
      endif()
    endif()
  endforeach()
  if(msg)
    string(REGEX REPLACE "\n" "\n actual-out> " actual_out " actual-out> ${actual_stdout}")
    string(REGEX REPLACE "\n" "\n actual-err> " actual_err " actual-err> ${actual_stderr}")
    message(SEND_ERROR "${test} - FAILED:\n"
      "${msg}"
      "${expect_out}"
      "Actual stdout:\n${actual_out}\n"
      "${expect_err}"
      "Actual stderr:\n${actual_err}\n"
      )
  else()
    message(STATUS "${test} - PASSED")
  endif()
endfunction()

run_test(MissingNormal)
run_test(MissingNormalRequired)
run_test(MissingNormalVersion)
run_test(MissingNormalWarnNoModuleOld)
run_test(MissingNormalWarnNoModuleNew)
run_test(MissingModule)
run_test(MissingModuleRequired)
run_test(MissingConfig)
run_test(MissingConfigOneName)
run_test(MissingConfigRequired)
run_test(MissingConfigVersion)
run_test(MixedModeOptions)
